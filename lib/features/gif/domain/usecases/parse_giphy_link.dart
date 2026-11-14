// ============================================================================
// USE CASE: PARSE GIPHY LINK
// ============================================================================
// Vérifie un lien collé par l'utilisateur et le transforme en adresse
// d'image. Seul GIPHY est accepté, le même fournisseur que l'API de tirage :
// - page d'un GIF : giphy.com/gifs/nom-ID, convertie en
//   https://media.giphy.com/media/ID/giphy.gif
// - image directe : media.giphy.com, i.giphy.com, media0 à media4.giphy.com,
//   gardée telle quelle (en https) si elle finit par .gif ou .webp
// Un lien sans "https://" est accepté. Aucun appel réseau : un GIF supprimé
// de GIPHY passera la validation et s'affichera "GIF indisponible".

import '../entities/giphy_link_result.dart';

class ParseGiphyLink {
  const ParseGiphyLink();

  // --- Sites des pages de GIF ---
  static const Set<String> _pageHosts = {'giphy.com', 'www.giphy.com'};

  // --- Sites des images ---
  static const Set<String> _imageHosts = {
    'media.giphy.com',
    'i.giphy.com',
    'media0.giphy.com',
    'media1.giphy.com',
    'media2.giphy.com',
    'media3.giphy.com',
    'media4.giphy.com',
  };

  // --- Formats que Image.network sait afficher en animé ---
  static const List<String> _imageExtensions = ['.gif', '.webp'];

  // --- Identifiant d'un GIF : lettres et chiffres ---
  static final RegExp _gifId = RegExp(r'^[A-Za-z0-9]+$');

  GiphyLinkResult call(String input) {
    final text = input.trim();
    if (text.isEmpty) return const GiphyLinkRejected(GiphyLinkRejection.empty);
    if (text.contains(RegExp(r'\s'))) {
      return const GiphyLinkRejected(GiphyLinkRejection.notALink);
    }

    final uri = _parse(text);
    if (uri == null) {
      return const GiphyLinkRejected(GiphyLinkRejection.notALink);
    }

    final host = uri.host.toLowerCase();
    if (_pageHosts.contains(host)) return _fromPage(uri);
    if (_imageHosts.contains(host)) return _fromImage(uri);
    return const GiphyLinkRejected(GiphyLinkRejection.notGiphy);
  }

  // --- Ajoute "https://" s'il manque, puis vérifie que c'est une adresse
  // --- web avec un nom de site qui ressemble à un domaine ---
  static Uri? _parse(String text) {
    final withScheme = text.contains('://') ? text : 'https://$text';
    final uri = Uri.tryParse(withScheme);
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    if (!uri.host.contains('.')) return null;
    return uri;
  }

  // --- giphy.com/gifs/nom-ID : l'identifiant suit le dernier tiret. Un
  // --- lien sans nom (giphy.com/gifs/ID) marche aussi ---
  static GiphyLinkResult _fromPage(Uri uri) {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length < 2 || segments.first != 'gifs') {
      return const GiphyLinkRejected(GiphyLinkRejection.notAGif);
    }

    final id = segments[1].split('-').last;
    if (!_gifId.hasMatch(id)) {
      return const GiphyLinkRejected(GiphyLinkRejection.notAGif);
    }
    return GiphyLinkAccepted('https://media.giphy.com/media/$id/giphy.gif');
  }

  // --- Lien d'image : gardé tel quel, paramètres compris, mais en https ---
  static GiphyLinkResult _fromImage(Uri uri) {
    final path = uri.path.toLowerCase();
    final isImage = _imageExtensions.any(path.endsWith);
    if (!isImage) return const GiphyLinkRejected(GiphyLinkRejection.notAGif);

    final secure = uri.scheme == 'https' ? uri : uri.replace(scheme: 'https');
    return GiphyLinkAccepted(secure.toString());
  }
}
