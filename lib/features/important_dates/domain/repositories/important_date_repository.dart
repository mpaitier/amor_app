// ============================================================================
// IMPORTANT DATE REPOSITORY (INTERFACE)
// ============================================================================
// Contrat implémenté par la couche data. Le domaine ne dépend que de cette
// abstraction, jamais de Firestore directement.

import '../entities/important_date_entity.dart';

abstract class ImportantDateRepository {
  // --- Flux temps réel de toutes les dates importantes ---
  Stream<List<ImportantDateEntity>> watchImportantDates();

  // --- Ajoute une date, renvoie l'id du document créé ---
  Future<String> addImportantDate(ImportantDateEntity date);

  // --- Met à jour une date existante ---
  Future<void> updateImportantDate(ImportantDateEntity date);

  // --- Supprime une date ---
  Future<void> deleteImportantDate(String dateId);
}
