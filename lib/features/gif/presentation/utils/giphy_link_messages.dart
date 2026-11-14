// ============================================================================
// GIPHY LINK MESSAGES
// ============================================================================
// Message affiché sous le champ quand un lien GIPHY est refusé.

import '../../domain/entities/giphy_link_result.dart';

String giphyLinkErrorMessage(GiphyLinkRejection reason) {
  return switch (reason) {
    GiphyLinkRejection.empty => 'Colle d\'abord le lien d\'un GIF',
    GiphyLinkRejection.notALink => 'Ce texte n\'est pas un lien',
    GiphyLinkRejection.notGiphy => 'Seuls les liens GIPHY sont acceptés',
    GiphyLinkRejection.notAGif =>
      'Ce lien GIPHY ne mène pas à un GIF (giphy.com/gifs/...)',
  };
}
