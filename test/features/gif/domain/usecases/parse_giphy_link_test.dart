// ============================================================================
// TEST UNITAIRE : ParseGiphyLink (use case)
// ============================================================================
// Validation et conversion des liens GIPHY collés par l'utilisateur.

import 'package:flutter_test/flutter_test.dart';
import 'package:amor_app/features/gif/domain/entities/giphy_link_result.dart';
import 'package:amor_app/features/gif/domain/usecases/parse_giphy_link.dart';

void main() {
  const parse = ParseGiphyLink();
  const tId = 'l0MYt5jPR6QX5pnqM';
  const tMediaUrl = 'https://media.giphy.com/media/$tId/giphy.gif';

  void expectAccepted(String input, String gifUrl) {
    expect(parse(input), GiphyLinkAccepted(gifUrl), reason: input);
  }

  void expectRejected(String input, GiphyLinkRejection reason) {
    expect(parse(input), GiphyLinkRejected(reason), reason: input);
  }

  group('lien de page giphy.com/gifs', () {
    test('doit convertir nom-ID en lien d\'image', () {
      expectAccepted('https://giphy.com/gifs/happy-anniversary-$tId', tMediaUrl);
    });

    test('doit accepter un lien sans nom', () {
      expectAccepted('https://giphy.com/gifs/$tId', tMediaUrl);
    });

    test('doit accepter www, http et l\'absence de https://', () {
      expectAccepted('https://www.giphy.com/gifs/love-$tId', tMediaUrl);
      expectAccepted('http://giphy.com/gifs/love-$tId', tMediaUrl);
      expectAccepted('giphy.com/gifs/love-$tId', tMediaUrl);
    });

    test('doit ignorer la barre finale, les paramètres et les espaces', () {
      expectAccepted('https://giphy.com/gifs/love-$tId/', tMediaUrl);
      expectAccepted(
        'https://giphy.com/gifs/love-$tId?utm_source=share',
        tMediaUrl,
      );
      expectAccepted('  https://giphy.com/gifs/love-$tId \n', tMediaUrl);
    });

    test('doit accepter un nom de site en majuscules', () {
      expectAccepted('https://GIPHY.com/gifs/love-$tId', tMediaUrl);
    });

    test('doit refuser une page GIPHY qui n\'est pas un GIF', () {
      expectRejected('https://giphy.com', GiphyLinkRejection.notAGif);
      expectRejected('https://giphy.com/gifs', GiphyLinkRejection.notAGif);
      expectRejected(
        'https://giphy.com/search/love',
        GiphyLinkRejection.notAGif,
      );
      expectRejected(
        'https://giphy.com/clips/love-$tId',
        GiphyLinkRejection.notAGif,
      );
    });

    test('doit refuser un identifiant avec des caractères inattendus', () {
      expectRejected(
        'https://giphy.com/gifs/love-ab%20cd',
        GiphyLinkRejection.notAGif,
      );
      expectRejected('https://giphy.com/gifs/love-', GiphyLinkRejection.notAGif);
    });
  });

  group('lien d\'image', () {
    test('doit garder un lien media.giphy.com tel quel', () {
      expectAccepted(tMediaUrl, tMediaUrl);
    });

    test('doit accepter i.giphy.com et media0 à media4', () {
      expectAccepted(
        'https://i.giphy.com/$tId.gif',
        'https://i.giphy.com/$tId.gif',
      );
      for (var n = 0; n <= 4; n++) {
        final url = 'https://media$n.giphy.com/media/$tId/200.gif';
        expectAccepted(url, url);
      }
    });

    test('doit garder les paramètres d\'un lien d\'image', () {
      const url =
          'https://media1.giphy.com/media/v1.Y2lkPTc5/$tId/giphy.gif?cid=abc&ct=g';
      expectAccepted(url, url);
    });

    test('doit accepter le format webp', () {
      const url = 'https://media.giphy.com/media/$tId/giphy.webp';
      expectAccepted(url, url);
    });

    test('doit passer un lien http en https', () {
      expectAccepted('http://media.giphy.com/media/$tId/giphy.gif', tMediaUrl);
    });

    test('doit refuser une vidéo ou un lien sans image', () {
      expectRejected(
        'https://media.giphy.com/media/$tId/giphy.mp4',
        GiphyLinkRejection.notAGif,
      );
      expectRejected(
        'https://media.giphy.com/media/$tId/',
        GiphyLinkRejection.notAGif,
      );
    });

    test('doit refuser un sous-domaine media hors liste', () {
      expectRejected(
        'https://media5.giphy.com/media/$tId/giphy.gif',
        GiphyLinkRejection.notGiphy,
      );
    });
  });

  group('liens refusés', () {
    test('doit refuser un champ vide', () {
      expectRejected('', GiphyLinkRejection.empty);
      expectRejected('   ', GiphyLinkRejection.empty);
    });

    test('doit refuser un texte qui n\'est pas un lien', () {
      expectRejected('mon gif préféré', GiphyLinkRejection.notALink);
      expectRejected('hedgehog', GiphyLinkRejection.notALink);
      expectRejected('ftp://giphy.com/gifs/$tId', GiphyLinkRejection.notALink);
    });

    test('doit refuser les autres fournisseurs', () {
      expectRejected(
        'https://tenor.com/view/love-gif-123456',
        GiphyLinkRejection.notGiphy,
      );
      expectRejected(
        'https://i.imgur.com/abc123.gif',
        GiphyLinkRejection.notGiphy,
      );
    });

    test('doit refuser un faux domaine qui contient giphy', () {
      expectRejected(
        'https://giphy.com.evil.example/gifs/love-$tId',
        GiphyLinkRejection.notGiphy,
      );
      expectRejected(
        'https://notgiphy.com/gifs/love-$tId',
        GiphyLinkRejection.notGiphy,
      );
    });
  });
}
