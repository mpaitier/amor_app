// ============================================================================
// USE CASE: GET GIF SEARCH TERM
// ============================================================================
// Terme de recherche Giphy choisi dans les paramètres, lu une fois au moment
// de tirer un GIF. Sans réglage lisible, le terme d'origine est utilisé.

import '../entities/couple_settings_entity.dart';
import '../repositories/couple_settings_repository.dart';

class GetGifSearchTerm {
  final CoupleSettingsRepository _repository;
  const GetGifSearchTerm(this._repository);

  Future<String> call() async {
    try {
      final settings = await _repository.watchSettings().first;
      final term = settings.gifSearchTerm.trim();
      return term.isEmpty ? CoupleSettingsEntity.defaultGifSearchTerm : term;
    } catch (_) {
      return CoupleSettingsEntity.defaultGifSearchTerm;
    }
  }
}
